# Copyright © 2004-2017 Jakub Wilk <jwilk@jwilk.net>.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

version = $(shell head -n1 doc/changelog | cut -d ' ' -f2 | tr -d '()')
pod2man = $(shell which pod2man)

CC ?= gcc
CFLAGS ?= -g -O2
CFLAGS += -Wall -Wformat -Wextra -pedantic
CPPFLAGS += -DVERSION='"$(version)"'

PREFIX = /usr/local
DESTDIR =

.PHONY: all
all: shellcat

shellcat: shellcat.c
	$(LINK.c) $(<) -o $(@)

.PHONY: install
install: shellcat
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m755 $(<) $(DESTDIR)$(PREFIX)/bin/$(<)

.PHONY: clean
clean:
	rm -f shellcat

ifneq "$(pod2man)" ""

all: doc/shellcat.1

doc/shellcat.1: doc/manpage.pod
	sed -e 's/L<\([a-z_-]\+\)(\([0-9]\+\))>/B<\1>(\2)/' $(<) \
	| pod2man --utf8 -c '' -n SHELLCAT -r 'shellcat $(version)' \
	> $(@).tmp
	mv $(@).tmp $(@)

install: install-doc

.PHONY: install-doc
install-doc: doc/shellcat.1
	install -d $(DESTDIR)$(PREFIX)/share/man/man1
	install -m644 $(<) $(DESTDIR)$(PREFIX)/share/man/man1/$(notdir $(<))

clean: clean-doc

.PHONY: clean-doc
clean-doc:
	rm -f doc/*.1 doc/*.tmp

endif

# vim:ts=4 sts=4 sw=4 noet
