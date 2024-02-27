locals {
	cvs_volume_usage_warning_threshold = 80
	cvs_volume_expansion_threshold 	   = 90
	cvs_capacity_margin 			   = 70					# Expands volume to the extent so that disk usage reduces to 70%
	cvs_name               = "${var.customer}-${var.env}-cvs"
}