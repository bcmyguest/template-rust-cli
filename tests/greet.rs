//! Integration test: exercises the public library API from outside the
//! crate, exactly as a downstream user would.

use template_rust_cli::greet;

#[test]
fn greet_is_public_api() {
    assert_eq!(greet("integration"), "Hello, integration!");
}
