impl Solution {
    pub fn move_zeroes(nums: &mut Vec<i32>) {
        let len = nums.len();
        for idx in 1..len {
            if nums[idx-1] == 0 {
                for j in idx..len {
                    if nums[j] != 0 {
                        nums.swap(idx-1, j);
                        break;
                    }
                }
            }
        }
    }
}