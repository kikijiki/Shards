// The API isBadVersion is defined for you.
// bool isBadVersion(int version);

class Solution {
public:
    int firstBadVersion(int n) {
        int min = 0;
        int max = n;
        
        while(min != max){
            int mid = min + (max-min)/2;
            if(isBadVersion(mid))
                max = mid;
            else
                min = mid+1;
        }
        
        return max;
    }
};