deploy:
  $(eval VERSION := $(shell cat package.json | grep 'version' | cut -d\" -f4))
	git tag v$(VERSION) -s -m ""
	git push origin --tags
