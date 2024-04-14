impl Solution {
    pub fn longest_common_prefix(strs: Vec<String>) -> String {
        let strs: Vec<Vec<char>> = strs.into_iter().map(|s| s.chars().collect()).collect();

        let mut idx = 0;
        loop {
            let mut c = strs
                .iter()
                .map(|s| if idx < s.len() { Some(s[idx]) } else { None });

            if !match c.next() {
                Some(Some(first)) => c.all(|x| x == Some(first)),
                Some(None) => false,
                None => false,
            } {
                return strs[0][0..idx].into_iter().collect();
            }

            idx += 1;
        }
    }
}
