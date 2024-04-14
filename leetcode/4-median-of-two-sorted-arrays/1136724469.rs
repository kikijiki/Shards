impl Solution {
    pub fn find_median_sorted_arrays(nums1: Vec<i32>, nums2: Vec<i32>) -> f64 {
        let mut merged: Vec<i32> = nums1.iter().chain(nums2.iter()).cloned().collect();
        merged.sort();

        let len = merged.len();

        if merged.is_empty(){
            return 0f64;
        }

        let mid = len / 2;
        if len % 2 == 0 {
            return (merged[mid-1] as f64 + merged[mid] as f64) / 2.0f64;
        } else {
            return merged[mid] as f64;
        }
    }
}