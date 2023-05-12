#include <db_cxx.h>

#include <sys/types.h>
#include <sys/stat.h>

#include <string>
#include <vector>

#include <fstream>
#include <iostream>
#include <pthread.h>

#include <chrono>



int main(int argc, char** argv) {

    time_t start = clock();

    if(argc < 4) {
        return -1;
    }

    auto databaseFilename = argv[1];
    auto speciesKeysFilename = argv[2];
    auto proteinKeysFilename = argv[3];

    std::ofstream outfile(argv[4],std::ios_base::out);

    std::string line;

    // Init for species key
    std::ifstream speciesKeysFile(speciesKeysFilename);
    std::vector<std::string> specimen;

    // Insert all species in a vector;
    while(std::getline(speciesKeysFile,line)) {
        specimen.push_back(line);
    }

    // Init for proteins key
    std::ifstream proteinKeysFile(proteinKeysFilename);
    std::vector<std::string> proteins;

    // Insert all proteins in a vector;
    while(std::getline(proteinKeysFile,line)) {
        proteins.push_back(line.substr(0, line.find_first_of('\t')));
    }

    outfile << "species";

    for(auto protein : proteins)
        outfile << "\t" << protein;

    outfile << std::endl;

    
    Db dbv(NULL, 0);
    int err = dbv.verify(databaseFilename,NULL, &std::cout, 0u);
    
    Db dbm(NULL, 0);
    dbm.open(NULL,databaseFilename,NULL, DB_HASH, DB_RDONLY,S_IROTH);

    for(auto species : specimen) {
        outfile << species;

        for(auto protein : proteins) {
            std::string name = species + "_" + protein;
            
            Dbt key = Dbt(&name[0], name.size() * sizeof(char));

            Dbt value = Dbt(NULL, 0);
            value.set_flags(DB_DBT_MALLOC);
            int err = dbm.get(NULL,&key, &value, 0u);
            
            if(err == 0) {            
                if(value.get_size() > 0) {
                    int val = atoi(static_cast<char*>(value.get_data()));
                    outfile << "\t" << val;
                }
            }
            else if(err == DB_NOTFOUND) {
                outfile << "\t" << 0;
            }
            else
                outfile << "\t" << "#" << err;            
        }

        outfile << std::endl;
    }

    dbm.close(0);
    outfile.close();

    time_t diff = clock() - start;
    std::cout << diff / (double)(CLOCKS_PER_SEC) << std::endl;
    return 0;
}