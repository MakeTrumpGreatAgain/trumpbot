#!/bin/bash
# Note: I purposedly wrote this crap in awk, bash and more to see what can one
# do with such basic tools.

# Create a pipe to "loop" the input, so the final print can be brought back to the
# client with netcat
mkfifo pipe

# Configuration for the syntaxnet program
PARSER_EVAL=bazel-bin/syntaxnet/parser_eval
MODEL_DIR=syntaxnet/models/parsey_mcparseface
INPUT_FORMAT=stdin

trap exit SIGINT

while true ; do  # Run continously
	# Listen on port 80. The input (what gets sent to the client back) is what's written to pipe
	echo "Running"
	nc -l -p 80 < pipe | tee /proc/self/fd/2 | \
		awk -W interactive '
			BEGIN { content = 0 }
			content == 1 { if (length($0) > 0) print; fflush(); }  # Only write content after discarding headers
			/^\r?$/ { content = 1; next }' | \
		(while read -r line ; do
			# Run syntaxnet
			echo $line | $PARSER_EVAL \
					--input=$INPUT_FORMAT \
					--output=stdout-conll \
					--hidden_layer_sizes=64 \
					--arg_prefix=brain_tagger \
					--graph_builder=structured \
					--task_context=$MODEL_DIR/context.pbtxt \
					--model_path=$MODEL_DIR/tagger-params \
					--slim_model \
					--batch_size=1024 \
					--alsologtostderr | \
				$PARSER_EVAL \
					--input=stdin-conll \
					--output=stdout-conll \
					--hidden_layer_sizes=512,512 \
					--arg_prefix=brain_parser \
					--graph_builder=structured \
					--task_context=$MODEL_DIR/context.pbtxt \
					--model_path=$MODEL_DIR/parser-params \
					--slim_model \
					--batch_size=1024 \
					--alsologtostderr | \
				awk '
				BEGIN { printed = 0 }
				($8 == "ROOT" || $8 ~ /.*subj.*/ || $8 ~ /.*obj.*/) && ($4 == "VERB" || $4 == "NOUN") { print $7, $2; printed = 1 }
				END { if (printed == 0) print }' | \
				sort -n | head -n 4 | awk '{ print $2 }' | tr '\n' ' ' | tee /proc/self/fd/2
				# Print only the first 4 words, sorted by depth
		done) > pipe
done
