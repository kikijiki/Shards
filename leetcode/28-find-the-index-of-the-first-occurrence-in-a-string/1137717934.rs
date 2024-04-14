impl Solution {
    pub fn str_str(haystack: String, needle: String) -> i32 {
        match haystack.find(&needle) {
            Some(idx) => idx as i32,
            None => -1,
        }
    }
}