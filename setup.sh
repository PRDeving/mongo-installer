#!/bin/sh

echo "======================================="
echo "|     script written by PRDeving      |"
echo "|       pablo.deving@gmail.com        |"
echo "|      Last update: 20 Nov 2015       |"
echo "|                                     |"
case "$(uname -s)" in
    "Darwin")
            echo "|   INSTALLING MONGODB IN MAC OS X    |"
            echo "======================================="

            # CHECK BREW
            if [ "$(which brew)" != "" ]
            then
                echo "\nupdating brew..."
                brew update
            else
                echo "\nThe best way to install mongodb is by using brew"
                echo "but brew is not installed in your system."
                echo "you can install mongodb without brew with this script"
                echo "but you will not be able to install the php module"
                read -p "\nDo you want to install Brew? [Y/N]" response
                case $response in
                    [yY]* )
                        echo "\n\nInstalling homebrew..."
                        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
                        brew update
                        ;;
                    *)
                        echo "downloading..."
                        curl -O https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-3.0.7.tgz
                        echo "extracting mongodb in tmp folder"
                        tar -zxvf mongodb-osx-x86_64-3.0.7.tgz -C /tmp/
                        echo "coping mongodb to $HOME/mongodb"
                        mv tmp/mongodb-osx-x86_64-3.0.7/ $HOME/mongodb
                        echo "exporting path"
                        echo $HOME/.bashrc >> "export PATH=$HOME/mongodb/bin:$PATH"
                        exit
                        ;;
                esac
            fi

            echo "\nInstalling mongoDB via brew installer\n\n"
            brew install mongodb autoconf
            if [ "$(which mongod)" != "" ]
            then
                echo "\n\nMongoDB has been succesfully installed, now"
                echo "you can use mongod to run the mongo service"
                read -p "Do you want to install the php module? [Y/N]" resp
                echo "====================================================="
                echo "This installation probably wont give you acces to the"
                echo "PHP Mongo Driver out of the box, there are tons of"
                echo "variables in mac that can make this script fail, so"
                echo "the module will be installed and you will have to "
                echo "link it to your php installation manually"
                case $resp in
                    [yY]*)
                        if [ "$(which pecl)" == "" ]
                        then
                            echo "\n\nPEAR/PECL has not installed in this system,"
                            echo "Do you want to install it to follow with the"
                            read -r -p "installation? [Y/N]" response
                            case $response in
                                [yY]*)
                                    curl -O http://pear.php.net/go-pear.phar

                                    echo "\n\nPEAR installation is little tricky in MACOSX"
                                    echo "to make a correct installation follow this steps:"
                                    echo "\n1) in the first menu type 1 and RETURN"
                                    echo " enter /usr/local/pear and RETURN"
                                    echo "2) type 4 and press RETURN"
                                    echo " enter /usr/local/bin and RETURN"
                                    echo "3) press RETURN"
                                    sudo php -d detect_unicode=0 go-pear.phar

                                    if [ "$(which pear)" != "" ]
                                    then
                                        echo "\n\npear has been succesfully installed"
                                    fi
                                    ;;
                                *)
                                    exit
                                    ;;
                            esac
                        fi

                        sudo pecl install mongo
                        
                        if [ -f "/etc/php5/apache2/php.ini" ]
                        then
                            sudo echo "extension=mongo.so" >> /etc/php5/apache2/php.ini
                            if [ "$(which apachectl)" != "" ]
                            then
                                sudo apachectl restart
                            else
                                echo "\n\nThe installation has been succesfull, restart apache"
                            fi
                        else
                            echo "\n\nThe instalator couldn´t find the php.ini file"
                            echo "please, add 'extension=mongo.so' in your php.ini"
                            echo "and restart apache by running 'apachectl restart'"
                        fi
                        exit
                        ;;
                    *)
                        exit
                        ;;
                esac

            else
                echo "The installation has failed"
                exit
            fi
        ;;
    "Linux")
        echo "|   INSTALLING MONGODB IN LINUX OS    |"
        echo "======================================="
        if [ "$(which apt-get)" != "" ]
        then
            echo "Updating repositories..."
            apt-get update
            echo "\n\nInstalling MongoDB..."
            apt-get install mongo

            if [ "$(which mongod)" != "" ]
            then
                echo "mongo has been installed succesfully"
            
                read -p "Do you want to install the php module of MongoDB? [Y/N]" ans
                case $ans in
                    [yY]*)
                        echo "installing PEAR/PECL"
                        apt-get install php5-dev php-pear
                        if [ "$(which pear)" != "" ]
                        then
                            echo "\nPEAR correctly installed"
                            pecl install mongo
                        else
                            echo "Error installing PEAR"
                            exit
                        fi
                        if [ -f "/etc/php5/apache2/php.ini" ]
                        then
                            sudo echo "extension=mongo.so" >> /etc/php5/apache2/php.ini
                            echo "add extension to php.ini";
                        else
                            echo "php.ini was not found, please add \"extension=mongo.so\""
                            echo "to your php.ini file and restart apache"
                            exit
                        fi
                        if [ "$(which apachectl)" != "" ]
                        then
                            echo "\n\nrestarting apache"
                            sudo apachectl restart
                        else
                            echo "mongoDB php module has been correctly installed"
                            echo "restart apache"
                        fi
                        ;;
                    *)
                        ;;
                esac
            else
                echo "error installing mongo"
                exit
            fi
        else
            echo "this script only suports apt-get based systems"
            exit
        fi
        ;;
    esac

