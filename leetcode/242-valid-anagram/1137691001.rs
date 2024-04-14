use std::collections::HashMap;

impl Solution {
    pub fn is_anagram(s: String, t: String) -> bool {
        let mut h1 = HashMap::new();
        for c in s.chars() {
            *h1.entry(c).or_insert(0) += 1;
        }
        
        let mut h2 = HashMap::new();
        for c in t.chars() {
            *h2.entry(c).or_insert(0) += 1;
        }
        
        return h1 == h2;
    }
}