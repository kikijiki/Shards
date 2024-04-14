impl Solution {
    pub fn height_checker(heights: Vec<i32>) -> i32 {
        //let mut exp = heights.clone();
        //
        // Bubble Sort
        //for i in 0..exp.len() - 1 {
        //    for j in i+1..exp.len() {
        //        if exp[i] > exp[j] {
        //            exp.swap(i, j);
        //        }
        //    }
        //}
        
        
        let mut exp = heights.clone();
        exp.sort();
        
        exp.iter().zip(heights).filter(|&(a, b)| *a != b).count() as i32
    }
}