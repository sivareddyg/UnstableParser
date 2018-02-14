# StagA Slide Experiments based on "Transition-based dependency parsing exploiting supertags"
notag-staga-data:
	mkdir -p data/conll2017-notag-staga/UD_English
	cat data/ud-treebanks-conll2017/UD_English/en-ud-train.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> working/en-ud-train.conllu.$@.tmp
	java -cp .:corenlp.jar edu.stanford.nlp.trees.linearize.LinearizedDependencyTagger \
		-inputFile working/en-ud-train.conllu.$@.tmp \
		-outFile data/conll2017-notag-staga/UD_English/en-ud-train.conllu \
		-slideKey slide.stag-a \
		-coreArguments "nsubj;nsubjpass;obj;iobj;csubj;csubjpass;ccomp;xcomp"
	rm working/en-ud-train.conllu.$@.tmp
	
	cat data/ud-treebanks-conll2017/UD_English/en-ud-dev.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> working/en-ud-dev.conllu.$@.tmp
	java -cp .:corenlp.jar edu.stanford.nlp.trees.linearize.LinearizedDependencyTagger \
		-inputFile working/en-ud-dev.conllu.$@.tmp \
		-outFile data/conll2017-notag-staga/UD_English/en-ud-dev.conllu \
		-slideKey slide.stag-a \
		-coreArguments "nsubj;nsubjpass;obj;iobj;csubj;csubjpass;ccomp;xcomp"
	rm working/en-ud-dev.conllu.$@.tmp

	cat data/ud-test-v2.0-conll2017/gold/conll17-ud-test-2017-05-09/en.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> working/en-ud-test.conllu.$@.tmp
	java -cp .:corenlp.jar edu.stanford.nlp.trees.linearize.LinearizedDependencyTagger \
		-inputFile working/en-ud-test.conllu.$@.tmp \
		-outFile data/conll2017-notag-staga/UD_English/en-ud-test.conllu \
		-slideKey slide.stag-a \
		-coreArguments "nsubj;nsubjpass;obj;iobj;csubj;csubjpass;ccomp;xcomp"
	rm working/en-ud-test.conllu.$@.tmp

	cat data/ud-test-v2.0-conll2017/input/conll17-ud-test-2017-05-09/en-udpipe.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> data/conll2017-notag-staga/UD_English/en-ud-test.udpipe.conllu

train-notag-staga-tagger:
	python main.py \
		--save_dir saves/notag-staga/tagger \
		train \
		--config_file config/tagger-staga.cfg

evaluate-notag-staga-tagger:
	mkdir -p working/notag-staga/tagger
	python main.py \
		--save_dir saves/notag-staga/tagger \
		parse \
		data/conll2017-notag-staga/UD_English/en-ud-train.conllu \
		data/conll2017-notag-staga/UD_English/en-ud-dev.conllu \
		data/conll2017-notag-staga/UD_English/en-ud-test.conllu \
		data/conll2017-notag-staga/UD_English/en-ud-test.udpipe.conllu \
		--output_dir working/notag-staga/tagger

results-notag-staga-tagger:
	# Dev
	python scripts/evaluate_supertagger.py \
		data/conll2017-notag-staga/UD_English/en-ud-dev.conllu \
		working/notag-staga/tagger/en-ud-dev.conllu

	# Test
	python scripts/evaluate_supertagger.py \
		data/conll2017-notag-staga/UD_English/en-ud-test.conllu \
		working/notag-staga/tagger/en-ud-test.conllu

train-staga-parser:
	mkdir -p saves/notag-staga/
	python main.py \
		--save_dir saves/notag-staga/parser \
		train \
		--config_file config/parser-notag-staga.cfg

evaluate-notag-staga-parser:
	mkdir -p working/notag-staga/parser
	python main.py \
		--save_dir saves/notag-staga/parser \
		parse \
		working/notag-staga/tagger/en-ud-train.conllu \
		working/notag-staga/tagger/en-ud-dev.conllu \
		working/notag-staga/tagger/en-ud-test.conllu \
		working/notag-staga/tagger/en-ud-test.udpipe.conllu \
		--output_dir working/notag-staga/parser

results-notag-staga-parser:
	# Gold tokenization
	## Dev
	python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
		data/conll2017-notag/UD_English/en-ud-dev.conllu \
		working/notag-staga/parser/en-ud-dev.conllu
	## Test
	python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
		data/conll2017-notag/UD_English/en-ud-test.conllu \
		working/notag-staga/parser/en-ud-test.conllu
	# UDPipe tokenization
	#	python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
	#	data/conll2017-notag/UD_English/en-ud-test.udpipe.conllu \
	#	working/notag-staga/parser/en-ud-test.udpipe.conllu

	# LS Score
	## Dev
	python scripts/compute_LS.py \
		working/notag-staga/parser/en-ud-dev.conllu \
		data/conll2017-notag-staga/UD_English/en-ud-dev.conllu
	## Test
	python scripts/compute_LS.py \
		working/notag-staga/parser/en-ud-test.conllu \
		data/conll2017-notag-staga/UD_English/en-ud-test.conllu

# StagB Slide Experiments based on "Transition-based dependency parsing exploiting supertags"
notag-stagb-data:
	mkdir -p data/conll2017-notag-stagb/UD_English
	cat data/ud-treebanks-conll2017/UD_English/en-ud-train.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> working/en-ud-train.conllu.$@.tmp
	java -cp .:corenlp.jar edu.stanford.nlp.trees.linearize.LinearizedDependencyTagger \
		-inputFile working/en-ud-train.conllu.$@.tmp \
		-outFile data/conll2017-notag-stagb/UD_English/en-ud-train.conllu \
		-slideKey slide.stag-b \
		-coreArguments "nsubj;nsubjpass;obj;iobj;csubj;csubjpass;ccomp;xcomp"
	rm working/en-ud-train.conllu.$@.tmp
	
	cat data/ud-treebanks-conll2017/UD_English/en-ud-dev.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> working/en-ud-dev.conllu.$@.tmp
	java -cp .:corenlp.jar edu.stanford.nlp.trees.linearize.LinearizedDependencyTagger \
		-inputFile working/en-ud-dev.conllu.$@.tmp \
		-outFile data/conll2017-notag-stagb/UD_English/en-ud-dev.conllu \
		-slideKey slide.stag-b \
		-coreArguments "nsubj;nsubjpass;obj;iobj;csubj;csubjpass;ccomp;xcomp"
	rm working/en-ud-dev.conllu.$@.tmp

	cat data/ud-test-v2.0-conll2017/gold/conll17-ud-test-2017-05-09/en.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> working/en-ud-test.conllu.$@.tmp
	java -cp .:corenlp.jar edu.stanford.nlp.trees.linearize.LinearizedDependencyTagger \
		-inputFile working/en-ud-test.conllu.$@.tmp \
		-outFile data/conll2017-notag-stagb/UD_English/en-ud-test.conllu \
		-slideKey slide.stag-b \
		-coreArguments "nsubj;nsubjpass;obj;iobj;csubj;csubjpass;ccomp;xcomp"
	rm working/en-ud-test.conllu.$@.tmp

	cat data/ud-test-v2.0-conll2017/input/conll17-ud-test-2017-05-09/en-udpipe.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> data/conll2017-notag-stagb/UD_English/en-ud-test.udpipe.conllu

train-notag-stagb-tagger:
	python main.py \
		--save_dir saves/notag-stagb/tagger \
		train \
		--config_file config/tagger-stagb.cfg

evaluate-notag-stagb-tagger:
	mkdir -p working/notag-stagb/tagger
	python main.py \
		--save_dir saves/notag-stagb/tagger \
		parse \
		data/conll2017-notag-stagb/UD_English/en-ud-train.conllu \
		data/conll2017-notag-stagb/UD_English/en-ud-dev.conllu \
		data/conll2017-notag-stagb/UD_English/en-ud-test.conllu \
		data/conll2017-notag-stagb/UD_English/en-ud-test.udpipe.conllu \
		--output_dir working/notag-stagb/tagger

results-notag-stagb-tagger:
	# Dev
	python scripts/evaluate_supertagger.py \
		data/conll2017-notag-stagb/UD_English/en-ud-dev.conllu \
		working/notag-stagb/tagger/en-ud-dev.conllu

	# Test
	python scripts/evaluate_supertagger.py \
		data/conll2017-notag-stagb/UD_English/en-ud-test.conllu \
		working/notag-stagb/tagger/en-ud-test.conllu

train-stagb-parser:
	mkdir -p saves/notag-stagb/
	python main.py \
		--save_dir saves/notag-stagb/parser \
		train \
		--config_file config/parser-notag-stagb.cfg

evaluate-notag-stagb-parser:
	mkdir -p working/notag-stagb/parser
	python main.py \
		--save_dir saves/notag-stagb/parser \
		parse \
		working/notag-stagb/tagger/en-ud-train.conllu \
		working/notag-stagb/tagger/en-ud-dev.conllu \
		working/notag-stagb/tagger/en-ud-test.conllu \
		working/notag-stagb/tagger/en-ud-test.udpipe.conllu \
		--output_dir working/notag-stagb/parser

results-notag-stagb-parser:
	# Gold tokenization
	## Dev
	python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
		data/conll2017-notag/UD_English/en-ud-dev.conllu \
		working/notag-stagb/parser/en-ud-dev.conllu
	## Test
	python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
		data/conll2017-notag/UD_English/en-ud-test.conllu \
		working/notag-stagb/parser/en-ud-test.conllu
	# UDPipe tokenization
	#	python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
	#	data/conll2017-notag/UD_English/en-ud-test.udpipe.conllu \
	#	working/notag-stagb/parser/en-ud-test.udpipe.conllu

	# LS Score
	## Dev
	python scripts/compute_LS.py \
		working/notag-stagb/parser/en-ud-dev.conllu \
		data/conll2017-notag-stagb/UD_English/en-ud-dev.conllu
	## Test
	python scripts/compute_LS.py \
		working/notag-stagb/parser/en-ud-test.conllu \
		data/conll2017-notag-stagb/UD_English/en-ud-test.conllu

# Simple Slide Experiments - just the dep label
notag-simpleslide-data:
	mkdir -p data/conll2017-notag-simpleslide
	cat data/ud-treebanks-conll2017/UD_English/en-ud-train.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> working/en-ud-train.conllu.$@.tmp
	java -cp .:corenlp.jar edu.stanford.nlp.trees.linearize.LinearizedDependencyTagger \
		-inputFile working/en-ud-train.conllu.$@.tmp \
		-outFile data/conll2017-notag-simpleslide/UD_English/en-ud-train.conllu \
		-slideKey slide.simple
	rm working/en-ud-train.conllu.$@.tmp
	
	cat data/ud-treebanks-conll2017/UD_English/en-ud-dev.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> working/en-ud-dev.conllu.$@.tmp
	java -cp .:corenlp.jar edu.stanford.nlp.trees.linearize.LinearizedDependencyTagger \
		-inputFile working/en-ud-dev.conllu.$@.tmp \
		-outFile data/conll2017-notag-simpleslide/UD_English/en-ud-dev.conllu \
		-slideKey slide.simple
	rm working/en-ud-dev.conllu.$@.tmp

	cat data/ud-test-v2.0-conll2017/gold/conll17-ud-test-2017-05-09/en.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> working/en-ud-test.conllu.$@.tmp
	java -cp .:corenlp.jar edu.stanford.nlp.trees.linearize.LinearizedDependencyTagger \
		-inputFile working/en-ud-test.conllu.$@.tmp \
		-outFile data/conll2017-notag-simpleslide/UD_English/en-ud-test.conllu \
		-slideKey slide.simple
	rm working/en-ud-test.conllu.$@.tmp

	cat data/ud-test-v2.0-conll2017/input/conll17-ud-test-2017-05-09/en-udpipe.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> data/conll2017-notag-simpleslide/UD_English/en-ud-test.udpipe.conllu

train-notag-simpleslide-tagger:
	python main.py \
		--save_dir saves/notag-simpleslide/tagger \
		train \
		--config_file config/tagger-simpleslide.cfg

evaluate-notag-simpleslide-tagger:
	mkdir -p working/notag-simpleslide/tagger
	python main.py \
		--save_dir saves/notag-simpleslide/tagger \
		parse \
		data/conll2017-notag-simpleslide/UD_English/en-ud-train.conllu \
		data/conll2017-notag-simpleslide/UD_English/en-ud-dev.conllu \
		data/conll2017-notag-simpleslide/UD_English/en-ud-test.conllu \
		data/conll2017-notag-simpleslide/UD_English/en-ud-test.udpipe.conllu \
		--output_dir working/notag-simpleslide/tagger

results-notag-simpleslide-tagger:
	# Dev
	python scripts/evaluate_supertagger.py \
		data/conll2017-notag-simpleslide/UD_English/en-ud-dev.conllu \
		working/notag-simpleslide/tagger/en-ud-dev.conllu

	# Test
	python scripts/evaluate_supertagger.py \
		data/conll2017-notag-simpleslide/UD_English/en-ud-test.conllu \
		working/notag-simpleslide/tagger/en-ud-test.conllu

#SimpleSlide Parsing Experiments
train-simpleslide-parser:
	mkdir -p saves/notag-simpleslide/
	python main.py \
		--save_dir saves/notag-simpleslide/parser \
		train \
		--config_file config/parser-notag-simpleslide.cfg

evaluate-notag-simpleslide-parser:
	mkdir -p working/notag-simpleslide/parser
	python main.py \
		--save_dir saves/notag-simpleslide/parser \
		parse \
		working/notag-simpleslide/tagger/en-ud-train.conllu \
		working/notag-simpleslide/tagger/en-ud-dev.conllu \
		working/notag-simpleslide/tagger/en-ud-test.conllu \
		working/notag-simpleslide/tagger/en-ud-test.udpipe.conllu \
		--output_dir working/notag-simpleslide/parser

results-notag-simpleslide-parser:
	# Gold tokenization
	## Dev
	python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
		data/conll2017-notag/UD_English/en-ud-dev.conllu \
		working/notag-simpleslide/parser/en-ud-dev.conllu
	## Test
	python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
		data/conll2017-notag/UD_English/en-ud-test.conllu \
		working/notag-simpleslide/parser/en-ud-test.conllu
	# UDPipe tokenization
	#	python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
	#	data/conll2017-notag/UD_English/en-ud-test.udpipe.conllu \
	#	working/notag-simpleslide/parser/en-ud-test.udpipe.conllu

	# LS Score
	## Dev
	python scripts/compute_LS.py \
		working/notag-simpleslide/parser/en-ud-dev.conllu \
		data/conll2017-notag-simpleslide/UD_English/en-ud-dev.conllu
	## Test
	python scripts/compute_LS.py \
		working/notag-simpleslide/parser/en-ud-test.conllu \
		data/conll2017-notag-simpleslide/UD_English/en-ud-test.conllu

# No tag experiments
notag-data:
	mkdir -p data/conll2017-notag/
	cat data/ud-treebanks-conll2017/UD_English/en-ud-train.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> data/conll2017-notag/UD_English/en-ud-train.conllu 
	cat data/ud-treebanks-conll2017/UD_English/en-ud-dev.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> data/conll2017-notag/UD_English/en-ud-dev.conllu 
	cat data/ud-test-v2.0-conll2017/gold/conll17-ud-test-2017-05-09/en.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> data/conll2017-notag/UD_English/en-ud-test.conllu 
	cat data/ud-test-v2.0-conll2017/input/conll17-ud-test-2017-05-09/en-udpipe.conllu \
		| perl scripts/ud-tools-v2.0/conllu_to_conllx.pl \
		| python scripts/dummify_columns.py 2,3,4,5,9 \
		> data/conll2017-notag/UD_English/en-ud-test.udpipe.conllu 

notag-parser:
	python main.py \
		--save_dir saves/notag/parser \
		train \
		--config_file config/parser-notag.cfg

evaluate-notag-parser:
	mkdir -p working/notag/parser
	python main.py \
		--save_dir saves/notag/parser \
		parse \
		data/conll2017-notag/UD_English/en-ud-train.conllu \
		data/conll2017-notag/UD_English/en-ud-dev.conllu \
		data/conll2017-notag/UD_English/en-ud-test.conllu \
		data/conll2017-notag/UD_English/en-ud-test.udpipe.conllu \
		--output_dir working/notag/parser

results-notag-parser:
	# Gold tokenization
	## Dev
	python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
		data/conll2017-notag/UD_English/en-ud-dev.conllu \
		working/notag/parser/en-ud-dev.conllu
	## Test
	python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
		data/conll2017-notag/UD_English/en-ud-test.conllu \
		working/notag/parser/en-ud-test.conllu
	# UDPipe tokenization
		python data/ud-test-v2.0-conll2017/evaluation_script/conll17_ud_eval.py --verbose \
		data/conll2017-notag/UD_English/en-ud-test.conllu \
		working/notag/parser/en-ud-test.udpipe.conllu

	# LS Score
	## Dev
	python scripts/compute_LS.py \
		working/notag/parser/en-ud-dev.conllu \
		data/conll2017-notag/UD_English/en-ud-dev.conllu
	## Test
	python scripts/compute_LS.py \
		working/notag/parser/en-ud-test.conllu \
		data/conll2017-notag/UD_English/en-ud-test.conllu

