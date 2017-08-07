ITERATION=1.lru
PREFIX=/usr/local
LICENSE=PHP
VENDOR="John McFarlane"
MAINTAINER="Ryan Parman"
DESCRIPTION="CommonMark parsing and rendering library and program in C."
URL=https://commonmark.org
ACTUALOS=$(shell osqueryi "select * from os_version;" --json | jq -r ".[].name")
EL=$(shell if [[ "$(ACTUALOS)" == "Amazon Linux AMI" ]]; then echo alami; else echo el; fi)
RHEL=$(shell [[ -f /etc/centos-release ]] && rpm -q --queryformat '%{VERSION}' centos-release)

#-------------------------------------------------------------------------------

all:
	@echo "Run 'make standard' or 'make gfm'."

#-------------------------------------------------------------------------------

.PHONY: standard
standard: standard-vars info clean install-deps standard-clone compile install-tmp package move

.PHONY: gfm
gfm: gfm-vars info clean install-deps gfm-clone compile install-tmp package move

#-------------------------------------------------------------------------------

.PHONY: standard-vars
standard-vars:
	$(eval NAME=commonmark)
	$(eval VERSION=0.28.0)

.PHONY: gfm-vars
gfm-vars:
	$(eval NAME=commonmark-gfm)
	$(eval VERSION=0.27.1.gfm.4)

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
	@ echo "ITERATION:   $(ITERATION)"
	@ echo "PREFIX:      $(PREFIX)"
	@ echo "LICENSE:     $(LICENSE)"
	@ echo "VENDOR:      $(VENDOR)"
	@ echo "MAINTAINER:  $(MAINTAINER)"
	@ echo "DESCRIPTION: $(DESCRIPTION)"
	@ echo "URL:         $(URL)"
	@ echo "OS:          $(ACTUALOS)"
	@ echo "EL:          $(EL)"
	@ echo "RHEL:        $(RHEL)"
	@ echo " "

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -Rf /tmp/installdir* cmark*

#-------------------------------------------------------------------------------

.PHONY: install-deps
install-deps:
	yum install -y \
		cmake \
		make \
		python3 \
		re2c \
	;
	rm -f /bin/python
	ln -s /usr/local/bin/python3.6 /bin/python # Temporary change

#-------------------------------------------------------------------------------

.PHONY: standard-clone
standard-clone:
	git clone -q -b $(VERSION) https://github.com/jgm/cmark.git --depth=1;

.PHONY: gfm-clone
gfm-clone:
	git clone -q -b $(VERSION) https://github.com/github/cmark.git --depth=1;

.PHONY: compile
compile:
	cd cmark && \
		mkdir -p build && \
		cd build && \
		cmake .. && \
		make && \
		make test \
	;
	rm -f /bin/python
	ln -s /bin/python2 /bin/python # Let's put this back

#-------------------------------------------------------------------------------

.PHONY: install-tmp
install-tmp:
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION);
	cd cmark && \
		make install DESTDIR=/tmp/installdir-$(NAME)-$(VERSION);

#-------------------------------------------------------------------------------

.PHONY: package
package:

	# Main package
	fpm \
		-f \
		-s dir \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix / \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrdir 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-changelog CHANGELOG-$(NAME).txt \
		--rpm-dist $(EL)$(RHEL) \
		--rpm-auto-add-directories \
		usr/local/bin \
		usr/local/include \
		usr/local/lib \
		usr/local/share \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	[[ -d /vagrant/repo ]] && mv *.rpm /vagrant/repo/
