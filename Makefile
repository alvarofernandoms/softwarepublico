PACKAGE = colab-spb-theme
VERSION = 0.2.0
DISTDIR = dist
PACKAGE_NAME = $(PACKAGE)-$(VERSION)
TARBALL = $(PACKAGE_NAME).tar.gz

all:
	@echo Nothing to be $@, all good.

colab_dir=/usr/lib/colab

dist: clean
	mkdir -p $(DISTDIR)/$(PACKAGE_NAME) 
	tar --exclude=.git --exclude=$(DISTDIR) -cf - * | (cd $(DISTDIR)/$(PACKAGE_NAME) && tar xaf -)
	cd $(DISTDIR) &&  tar -caf $(TARBALL) $(PACKAGE_NAME)
	rm -r $(DISTDIR)/$(PACKAGE_NAME) 
clean:
	$(RM) $(TARBALL)
	$(RM) -r $(DISTDIR)

install:
	install -d -m 0755 $(DESTDIR)/$(colab_dir)/colab-spb-theme
	cp -vr colab_spb_theme  $(DESTDIR)/$(colab_dir)/colab-spb-theme
