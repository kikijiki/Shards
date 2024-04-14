impl Solution {
    pub fn plus_one(digits: Vec<i32>) -> Vec<i32> {
        let mut ret = digits.clone();
        let mut rem = 1;
        
        for i in (0..ret.len()).rev() {
            ret[i] += rem;
            rem = ret[i] / 10;
            ret[i] = ret[i] % 10;
            
            if rem == 0 {
                break;
            }
        }
    
        if rem != 0 {
            ret.insert(0,rem);
        }
        
        ret
    }
}