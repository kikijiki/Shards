impl Solution {
    pub fn contains_duplicate(nums: Vec<i32>) -> bool {
        let mut x = nums.clone();
        x.sort();
        for idx in 1..x.len() {
            if x[idx-1] == x[idx] {
                return true;
            }
        }
        return false;
    }
}