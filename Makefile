build:
	git add boards/* .github/workflows/build.yml build.yaml config/west.yml Makefile
	git commit -m "update boards"
	git push
