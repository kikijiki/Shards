impl Solution {
    pub fn intersect(nums1: Vec<i32>, nums2: Vec<i32>) -> Vec<i32> {
        let mut x1 = nums1.clone();
        x1.sort();
        
        let mut x2 = nums2.clone();
        x2.sort();
        
        let mut i1 = 0;
        let mut i2 = 0;
        
        let mut ret = Vec::new();
        
        while i1 < x1.len() && i2 < x2.len() {
            if x1[i1] < x2[i2] {
                i1 += 1;
            } else if x1[i1] > x2[i2] {
                i2 += 1;
            } else {
                ret.push(x1[i1]);
                i1 += 1;
                i2 += 1;
            }
        }
        
        return ret;
    }
}