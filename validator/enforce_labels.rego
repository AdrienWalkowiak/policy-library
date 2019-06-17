#
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Note: supported resource types for this rule: 
# - projects
# - buckets
# - k8s pods

package templates.gcp.GCPResourceLabelsV1

import data.validator.gcp.lib as lib

resource_types_to_scan = [
	"cloudresourcemanager.googleapis.com/Project",
	"storage.googleapis.com/Bucket",
	"compute.googleapis.com/Instance",
	"compute.googleapis.com/Image",
	"compute.googleapis.com/Disk",
]

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)
	asset := input.asset

	mandatory_labels := params.mandatory_labels[_]
	resource_is_to_scan(asset)
	not label_is_valid(mandatory_labels, asset)

	message := sprintf("%v doesn't have a required label.", [asset.name])

	metadata := {"resource": asset.name, "mandatory_labels": mandatory_labels}
}

resource_is_to_scan(asset) {
	resource_types_to_scan[_] == asset.asset_type
}

# generic label_is_valid for all resources
label_is_valid(label, asset) {
	resource := get_label(asset)
	resource_labels := lib.get_default(resource, "labels", {})
	labelValue := resource_labels[label]
}

# get_generic_label Object for standard resources
get_generic_label(asset) = resource {
	resource := asset.resource.data
}

# get_label for standard resources
# placeholder function: in case we run into non-standard location for labels

get_label(asset) = resource {
	resource_types_to_scan[_] == asset.asset_type
	resource := get_generic_label(asset)
}
