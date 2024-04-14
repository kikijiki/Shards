impl Solution {
    pub fn minimum_abs_difference(arr: Vec<i32>) -> Vec<Vec<i32>> {
        if arr.len() < 2 {
            return Vec::default();
        }
        
        let sorted = { let mut x = arr.clone(); x.sort(); x };
        let mut min_dist = i32::MAX;
        for i in 0..sorted.len() - 1 {
            min_dist = i32::min(min_dist, sorted[i+1] - sorted[i]);
        }
        
        let mut out = Vec::new();
        for i in 0..sorted.len() - 1 {
            let dist = sorted[i+1] - sorted[i];
            if dist == min_dist {
                out.push(vec![sorted[i], sorted[i+1]]);
            }
        }
        
        out
    }
}