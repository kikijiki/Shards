use std::collections::HashMap;

impl Solution {
    pub fn first_uniq_char(s: String) -> i32 {
        if(s.len() == 0){ return -1; }
        if(s.len() == 1){ return 0; }
        
        let mut u = HashMap::new();
        for (i,c) in s.chars().enumerate() {
            u.entry(c).or_insert((i,0)).1 += 1;
        }
        
        u.iter()
            .filter(|&(_, &(_, count))| count == 1)
            .min_by_key(|&(_, &(index, _))| index)
            .map_or(-1, |(_, &(index, _))| index as i32)
    }
}