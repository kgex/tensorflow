// RUN: dtensor-opt %s -split-input-file -dtensor-xla-spmd-integration | FileCheck %s

// Check all inputs, outputs, and operations have sharding attributes.
// CHECK-LABEL: func @check_layouts_are_converted_to_xla_sharding_attributes
// CHECK-SAME: (%arg0: tensor<8x8xi32> {mhlo.sharding = "", tf._layout = "sharding_specs:unsharded,unsharded, mesh:|x=1|0|0|/job:localhost/replica:0/task:0/device:CPU:0|use_xla_spmd"}) -> (tensor<8x8xi32> {mhlo.sharding = ""})
func.func @check_layouts_are_converted_to_xla_sharding_attributes(
  %arg0: tensor<8x8xi32> {tf._layout = "sharding_specs:unsharded,unsharded, mesh:|x=1|0|0|/job:localhost/replica:0/task:0/device:CPU:0|use_xla_spmd"}) -> (tensor<8x8xi32>) {
  // CHECK:      "tf.Identity"
  // CHECK-SAME: mhlo.sharding = ""
  // CHECK-NEXT: return
  %1 = "tf.DTensorLayout"(%arg0) {global_shape = #tf_type.shape<8x8>, layout = #dtensor.layout<sharding_specs:unsharded,unsharded, mesh:|x=1|0|0|/job:localhost/replica:0/task:0/device:CPU:0|use_xla_spmd>} : (tensor<8x8xi32>) -> tensor<8x8xi32>
  %2 = "tf.Identity"(%1) {_global_shape = [#tf_type.shape<8x8>], device = ""} : (tensor<8x8xi32>) -> tensor<8x8xi32>
  %3 = "tf.DTensorLayout"(%2) {global_shape = #tf_type.shape<8x8>, layout = #dtensor.layout<sharding_specs:unsharded,unsharded, mesh:|x=1|0|0|/job:localhost/replica:0/task:0/device:CPU:0|use_xla_spmd>} : (tensor<8x8xi32>) -> tensor<8x8xi32>
  return %3 : tensor<8x8xi32>
}

// -----

// Check that Layout ops not on XLA SPMD mesh is not allowed at this point.
func.func @check_layouts_not_xla_spmd_is_not_allowed(
  %arg0: tensor<8x8xi32> {tf._layout = "sharding_specs:x,unsharded, mesh:|x=1|0|0|/job:localhost/replica:0/task:0/device:CPU:0"}) -> (tensor<8x8xi32>) {
  // expected-error @+1 {{'tf.DTensorLayout' op Found a layout operation that is not on XLA SPMD mesh during XLA SPMD integration.}}
  %1 = "tf.DTensorLayout"(%arg0) {global_shape = #tf_type.shape<8x8>, layout = #dtensor.layout<sharding_specs:x,unsharded, mesh:|x=1|0|0|/job:localhost/replica:0/task:0/device:CPU:0>} : (tensor<8x8xi32>) -> tensor<8x8xi32>
  return %1 : tensor<8x8xi32>
}
