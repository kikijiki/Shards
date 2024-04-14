use std::collections::HashMap;

impl Solution {
    pub fn single_number(nums: Vec<i32>) -> i32 {
        let mut map = HashMap::<i32,i32>::new();
        for x in nums {
            *map.entry(x).or_insert(0) += 1;
        }
        return *map.iter().find(|(k,v)| **v == 1).unwrap().0;
    }
}