impl Solution {
    pub fn minimum_abs_difference(arr: Vec<i32>) -> Vec<Vec<i32>> {
        let arr = { let mut arr = arr.clone(); arr.sort_unstable(); arr };
        let min = arr
            .windows(2)
            .map(|window| window[1] - window[0])
            .min()
            .unwrap();
        arr
            .windows(2)
            .filter(|window| window[1] - window[0] == min)
            .map(|window| vec![window[0], window[1]])
            .collect()
    }
}