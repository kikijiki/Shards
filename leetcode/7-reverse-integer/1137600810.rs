impl Solution {
    pub fn reverse(x: i32) -> i32 {
        let mut out:i32 = 0;
        let mut z = i32::abs(x);
        
        while z > 0 {
            if let Some(temp) = out.checked_mul(10) {
                out = match temp.checked_add(z % 10) {
                    Some(val) => val,
                    None => return 0,
                };
            } else {
                return 0;
            }
            z /= 10;
        }
        
        if x > 0 {
            out
        } else {
            -out
        }
    }
}