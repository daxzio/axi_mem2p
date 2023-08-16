LINT_IGNORE+=\
    always-comb \
    no-trailing-spaces \
    line-length \
    unpacked-dimensions-range-ordering \
    parameter-name-style \
    enum-name-style \
    generate-label \
    macro-name-style

lint:
	#@echo $(addsprefix --rules, $(LINT_IGNORE))
	verible-verilog-lint  \
		--rules -always-comb,-no-trailing-spaces,-line-length,-unpacked-dimensions-range-ordering,-parameter-name-style,-enum-name-style,-generate-label,-macro-name-style \
		${RTL_SOURCES}

format:
	verible-verilog-format \
	    --inplace \
        --column_limit 120 \
		--indentation_spaces 4 \
		${RTL_SOURCES} 

# test:
# 	verible-verilog-format \
# 	    --inplace \
#         --column_limit 120 \
# 		--indentation_spaces 4 \
# 		../src/uart/*.sv
