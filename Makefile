STACK_NAME ?= eventful-lambda
PAYLOAD ?= '{"message": "Hello from SOURCE!"}'

deploy:
	aws cloudformation deploy --stack-name $(STACK_NAME) --template-file template.yaml --capabilities CAPABILITY_IAM

lambda: 
	aws lambda invoke \
		--function-name $$(aws cloudformation describe-stacks --stack-name $(STACK_NAME) --query 'Stacks[0].Outputs[?OutputKey==`Lambda`].OutputValue' --output text) \
		--payload $(subst SOURCE,Lambda,$(PAYLOAD)) /dev/null

sqs:
	aws sqs send-message \
		--queue-url $$(aws cloudformation describe-stacks --stack-name $(STACK_NAME) --query 'Stacks[0].Outputs[?OutputKey==`SQS`].OutputValue' --output text) \
		--message-body $(subst SOURCE,SQS,$(PAYLOAD))

sns:
	aws sns publish \
		--topic-arn $$(aws cloudformation describe-stacks --stack-name $(STACK_NAME) --query 'Stacks[0].Outputs[?OutputKey==`SNS`].OutputValue' --output text) \
		--message $(subst SOURCE,SNS,$(PAYLOAD))

sns-sqs:
	aws sns publish \
		--topic-arn $$(aws cloudformation describe-stacks --stack-name $(STACK_NAME) --query 'Stacks[0].Outputs[?OutputKey==`SNSSQS`].OutputValue' --output text) \
		--message $(subst SOURCE,SNS/SQS,$(PAYLOAD))