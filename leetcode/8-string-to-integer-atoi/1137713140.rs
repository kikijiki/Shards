impl Solution {
    pub fn my_atoi(s: String) -> i32 {
        let x = s.trim().chars().collect::<Vec<_>>();
        let len = x.len();
        if len == 0 {
            return 0;
        }
        
        let mut i = 0;
        let mut sign :i32= 1;
        let mut out:i32 = 0;
        
        if x[0] == '-' {
            sign = -1;
            i += 1;
        } else if x[0] == '+' {
            i += 1;
        } else if x[0] == '.' { 
            i += 1;
            return 0;
        }
        
        while i < len {
            match x[i] {
                '0'..='9' => {
                    let digit = x[i] as i32 - '0' as i32;
                    if sign == -1 {
                        out = out.saturating_mul(10).saturating_sub(digit);
                    } else {
                        out = out.saturating_mul(10).saturating_add(digit);
                    }
                },
                _ => break,
            }
            i += 1;
        }
        
        out
    }
}