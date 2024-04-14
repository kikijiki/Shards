impl Solution {
    pub fn two_sum(nums: Vec<i32>, target: i32) -> Vec<i32> {
        for (idx1, &v1) in nums.iter().enumerate() {
            for (idx2, &v2) in nums.iter().enumerate() {
                if idx1 == idx2 {
                    continue;
                }

                if v1 + v2 == target {
                    return vec![idx1 as i32, idx2 as i32];
                }
            }
        }

        return vec![-1, -1];
    }
}