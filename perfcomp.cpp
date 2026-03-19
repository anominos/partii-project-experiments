#include <iostream>
int main() {
    int g = 0;
    for (int i=0;i<10000000;++i){
        g += i;
    }
    std::cout << g << std::endl;
}
