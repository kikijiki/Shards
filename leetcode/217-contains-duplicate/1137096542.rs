use std::collections::HashSet;

impl Solution {
    pub fn contains_duplicate(nums: Vec<i32>) -> bool {
        let mut x = HashSet::with_capacity(nums.len());
        !nums.into_iter().all(|y| x.insert(y))
    }
}