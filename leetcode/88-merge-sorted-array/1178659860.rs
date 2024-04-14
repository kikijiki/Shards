impl Solution {
    pub fn merge(nums1: &mut Vec<i32>, m: i32, nums2: &mut Vec<i32>, n: i32) {
        let mut i1 = m-1;
        let mut i2 = n-1;
        for idx in (0..m+n).rev() {
            if i1 >= 0 && i2 >= 0 {
                if nums1[i1 as usize] > nums2[i2 as usize] {
                    nums1[idx as usize] = nums1[i1 as usize];
                    i1 -= 1;
                } else {
                    nums1[idx as usize] = nums2[i2 as usize];
                    i2 -= 1;
                }
            }
            else if i1 >= 0 {
                nums1[idx as usize] = nums1[i1 as usize];
                i1 -= 1;
            } else {
                nums1[idx as usize] = nums2[i2 as usize];
                i2 -= 1;
            }
        }
    }
}