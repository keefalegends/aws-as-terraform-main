resource "aws_sns_topic" "sns" {
  name = "techno-sns-pati-keefa"
}

resource "aws_sns_topic_subscription" "emailsns" {
  topic_arn = aws_sns_topic.sns.id
  protocol  = "email"
  endpoint  = "keefatudys@gmail.com"
}
