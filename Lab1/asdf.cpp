#include <iostream>
#include <vector>
#include <utility>
#include <cstdlib>
#include <ctime> 
#include <bits/stdc++.h>

#ifndef ARR_N
#define ARR_N 10000
#endif

std::vector<int> generateLargeArray(size_t size, size_t max_value) {
    std::vector<int> array(size);
    for (size_t i = 0; i < size; ++i) {
        array[i] = rand() % max_value; 
    }
    return array;
}

// Bubble Sort
void my_sort(std::vector<int>& array) {
    size_t n = array.size();
    for (size_t i = 0; i < n - 1; ++i) {
        for (size_t j = 0; j < n - i - 1; ++j) {
            if (array[j] > array[j + 1]) {
                int temp = array[j];
                array[j] = array[j + 1];
                array[j + 1] = temp;
            }
        }
    }
}

// Quick Sort Algorithm with Helper Function
int partition (std::vector<int> &vec, int low, int high) {

    int pivot = vec[high];
    int i = (low - 1);

    for (int j = low; j <= high - 1; j++) {

        if (vec[j] <= pivot) {
            i++;
            std::swap(vec[i], vec[j]);
        }
    }
    std::swap(vec[i + 1], vec[high]);
    return (i + 1);
}

void quick_sort(std::vector<int> &vec, int low, int high) {
    if (low < high) {
        int pi = partition(vec, low, high);

        quick_sort(vec, low, pi - 1);
        quick_sort(vec, pi + 1, high);
    }
}

int main() {
    // These parameters can be changed
    // const size_t ARRAY_SIZE = 10000; 
    const size_t MAX_VALUE = 100000; 

    std::vector<int> largeArray = generateLargeArray(ARR_N, MAX_VALUE);

#ifdef USE_QUICK
    std::cout << "Sorting using Quick Sort";
    quick_sort(largeArray, 0, ARR_N - 1);
#else
    std::cout << "Sorting using original Bubble Sort";
    my_sort(largeArray);
#endif
    
    //quick_sort(largeArray, ARRAY_SIZE - 1);
    //my_sort(largeArray);

    // Print the last 5 elements of the sorted array
    std::cout << "Last 5 elements of the sorted array: ";
    for (size_t i = ARR_N - 5; i < ARR_N; ++i) {
        std::cout << largeArray[i] << " ";
    }
    std::cout << "\n";

    return 0;
}
