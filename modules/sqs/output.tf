output "sqsQueue_id" {
  value = aws_sqs_queue.rtaAlertSqs.id
}

output "sqsQueue_arn" {
  value = aws_sqs_queue.rtaAlertSqs.arn
}

output "dlqsqsQueue_arn" {
  value = aws_sqs_queue.DLQrtaAlertSqs.arn
}

output "dlqsqsQueue_id" {
  value = aws_sqs_queue.DLQrtaAlertSqs.id
}

