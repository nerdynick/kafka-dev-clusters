VERSION=$(shell cat VERSION)

# Github Repo
# Examples: username/repo or github.com/username/repo
GITHUB_REPO=$(shell gh repo view --json url -t '{{.url}}')

.PHONY: clean
clean:
	rm -rf packages

.PHONY: setup
setup:
	mkdir -p packages

.PHONY: package-kafka-uno
package-kafka-uno: setup
	tar -czf packages/kafka-uno-$(VERSION).tar.gz --exclude=.gitignore --exclude=data --exclude=output --exclude=secrets --exclude=Makefile* -C ./kafka-uno .

.PHONY: package-kafka-tres
package-kafka-tres: setup
	tar -czf packages/kafka-tres-$(VERSION).tar.gz --exclude=.gitignore --exclude=data* --exclude=output --exclude=secrets --exclude=Makefile* -C ./kafka-tres .

.PHONY: package-all
package-all: package-kafka-uno package-kafka-tres

##
# Github Targets
#
# Create Releases, Upload the Tarballs and Checksums, and Publish the Release
##
.PHONY: github-create-release
github-create-release:
	gh release create $(VERSION) --generate-notes --draft --repo $(GITHUB_REPO)
	

.PHONY: github-upload
github-upload:
	gh release upload $(VERSION) ./packages/* --repo $(GITHUB_REPO)

.PHONY: github-publish-release
github-publish-release:
	gh release edit  $(VERSION) --draft=false  --repo $(GITHUB_REPO)