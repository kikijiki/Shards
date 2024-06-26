impl Solution {
    pub fn rotate(nums: &mut Vec<i32>, k: i32) {
        if k == 0 {
            return;
        }
        
        let k = k as usize % nums.len();
        nums.reverse();
        nums[..k].reverse();
        nums[k..].reverse();
    }
}