impl Solution {
    pub fn top_k_frequent(nums: Vec<i32>, k: i32) -> Vec<i32> {
        let mut counts = std::collections::HashMap::<i32, u32>::new();
        for x in nums {
            *counts.entry(x).or_insert(0) += 1;
        }
        let mut counts: Vec<(i32, u32)> = counts.into_iter().collect();
        counts.sort_by(|a, b| b.1.cmp(&a.1));
        counts.iter().map(|&(num, _)| num).take(k as usize).collect()
    }
}
