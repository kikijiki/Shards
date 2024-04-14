impl Solution {
    pub fn two_sum(nums: Vec<i32>, target: i32) -> Vec<i32> {
        for idx1 in 0..nums.len() - 1 {
            for idx2 in idx1 + 1..nums.len() {
                if nums[idx1] + nums[idx2] == target {
                    return vec![idx1 as i32, idx2 as i32];
                }
            }
        }
        return vec![-1, -1];
    }
}