PACKAGE = noosfero-spb
VERSION = $(shell cat VERSION)
DISTDIR = $(PACKAGE)-$(VERSION)
TARBALL = $(DISTDIR).tar.gz

all:
	@echo Nothing to be $@, all good.

plugins_dir=/usr/lib/noosfero/plugins
themes_dir=/usr/lib/noosfero/public/designs/themes
noosfero_dir=/usr/lib/noosfero

dist: clean
	mkdir -p dist/$(DISTDIR)
	tar --exclude=.git --exclude=$(DISTDIR) -cf - * | (cd dist/$(DISTDIR) && tar xaf -)
	cd dist/ && tar --exclude=.git -czf $(TARBALL) $(DISTDIR)
	$(RM) -r $(DISTDIR)

clean:
	$(RM) -r dist/

install:
	install -d -m 0755 $(DESTDIR)/$(plugins_dir)/software_communities
	cp -vr software_communities/* $(DESTDIR)/$(plugins_dir)/software_communities/
	install -d -m 0755 $(DESTDIR)/$(plugins_dir)/spb_migrations
	cp -vr spb_migrations/* $(DESTDIR)/$(plugins_dir)/spb_migrations/
	install -d -m 0755 $(DESTDIR)/$(themes_dir)/noosfero-spb-theme
	cp -vr noosfero-spb-theme/* $(DESTDIR)/$(themes_dir)/noosfero-spb-theme/
	install -d -m 0755 $(DESTDIR)/$(plugins_dir)/gov_user
	cp -vr gov_user/* $(DESTDIR)/$(plugins_dir)/gov_user/
	cd $(DESTDIR)/$(plugins_dir)/software_communities/ && \
	mkdir -p locale/pt/LC_MESSAGES && \
	msgfmt -o locale/pt/LC_MESSAGES/software_communities.mo po/pt/software_communities.po
	cd ..
	cd $(DESTDIR)/$(plugins_dir)/gov_user/ && \
	mkdir -p locale/pt/LC_MESSAGES && \
	msgfmt -o locale/pt/LC_MESSAGES/gov_user.mo po/pt/gov_user.po
