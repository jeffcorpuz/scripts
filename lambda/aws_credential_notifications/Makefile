build: clean
	cd files/lambda; \
	go get .; \
	GOOS=linux go build .

clean:
	cd files/lambda && rm -rf lambda
	cd .terraform && rm -rf archive_files

apply: build
	terraform plan
	terraform apply