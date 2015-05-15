# autogenerated DNS documentation

BUILT += dns.rst
dns.rst: ../test/dns_test.sh
	(cd .. && sh test/dns_test.sh --doc) > $@

BUILT += architecture.png
architecture.png: architecture.dot
	dot -Tpng -o $@ $<

SPB_ENV ?= local

BUILT += $(patsubst %.in, %, $(wildcard *.in))
%: %.in build.rb
	ruby -p build.rb $< > $@ || ($(RM) $@; false)

CLEAN_FILES += $(BUILT)
