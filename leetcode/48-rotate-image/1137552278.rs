impl Solution {
    pub fn rotate(matrix: &mut Vec<Vec<i32>>) {
        let len = matrix.len();
        
        for row in &mut *matrix {
            row.reverse();
        }
        
        for x in 0..len - 1 {
            for y in 0..len-x-1 {
                let tx = len - x - 1;
                let ty = len - y - 1;
                let tmp = matrix[x][y];
                matrix[x][y] = matrix[ty][tx];
                matrix[ty][tx] = tmp;
            }
        }
    }
}