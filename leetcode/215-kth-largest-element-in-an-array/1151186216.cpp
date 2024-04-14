class Solution {
public:
    void maxHeapify(vector<int>& nums, int n, int i) {
        int largest = i;         // Initialize largest as root
        int left    = 2 * i + 1; // Left child
        int right   = 2 * i + 2; // Right child

        // If left child is larger than root
        if (left < n && nums[left] > nums[largest])
            largest = left;

        // If right child is larger than largest so far
        if (right < n && nums[right] > nums[largest])
            largest = right;

        // If largest is not root
        if (largest != i) {
            swap(nums[i], nums[largest]);

            // Recursively heapify the affected sub-tree
            maxHeapify(nums, n, largest);
        }
    }

    void heapSort(vector<int>& nums) {
        int n = nums.size();

        // Build heap (rearrange array)
        for (int i = n / 2 - 1; i >= 0; i--)
            maxHeapify(nums, n, i);

        // One by one extract an element from heap
        for (int i = n - 1; i > 0; i--) {
            // Move current root to end
            swap(nums[0], nums[i]);

            // call maxHeapify on the reduced heap
            maxHeapify(nums, i, 0);
        }
    }
    
    int findKthLargest(vector<int>& nums, int k) {
        int n = nums.size();
        
        if(k < 1 || k > n)
            return 0;
        
        heapSort(nums);
        return nums[n - k];
    }
};