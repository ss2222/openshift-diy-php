import os, re, shutil
#
internalIp = os.environ['OPENSHIFT_DIY_IP']
runtimeDir = os.environ['OPENSHIFT_HOMEDIR'] + "/app-root/runtime"
repoDir = os.environ['OPENSHIFT_HOMEDIR'] + "/app-root/runtime/repo/openshift-diy-php"
Bash_File=os.environ('OPENSHIFT_HOMEDIR')

CurrentDir=os.path.abspath(os.path.join(os.getcwd(), '..'))
# CurrentDir=os.getcwd()+'\\openshift-diy-php-master'
# CurrentDir=os.path.dirname(os.path.realpath(__file__))
# Destination='E:\\Program Files win 7 2nd\\Ampps\\www\\trash\\my-test'
Destination=repoDir
print CurrentDir

def replace(file_pattern,file_target):
    # Read contents from file_target as a single string
    if os.path.isfile(file_target):
        pass
    else:
        file_pattern2 = open(file_pattern, 'r')
        pattern = file_pattern2.readlines()
        file_pattern2.close()

        file_handle2= open(file_target, 'wb')
        file_handle2.writelines(pattern)
        file_handle2.close()

    file_handle = open(file_target, 'r')
    # file_string1 = file_handle.read()
    file_string = file_handle.readlines()
    file_handle.close()
    file_pattern2 = open(file_pattern, 'r')
    pattern = file_pattern2.readlines()
    file_pattern2.close()
    file_handle2= open(file_target, 'a+b')
    i=-1
    t=-1
    for line in range(i+1, len(pattern)):
        I_S=0
        for j in range(t+1, len(file_string)):
            if pattern[line] in file_string[j] :
                I_S=1
                break
            else:
                pass
        if I_S==0 :
            file_handle2.writelines(pattern[line])
    file_handle2.close()




for root, dirs, files in os.walk(CurrentDir):
    print root
    print dirs
    print  files
    curent_path=root.split(CurrentDir)[1]+'\\'
    for dir2 in dirs:
        if os.path.isdir(Destination+ curent_path+dir2):
            pass
        else:
            if not os.path.isdir(Destination):os.mkdir(Destination)
            os.mkdir(Destination+ curent_path+dir2)
    for file2 in files:
        if os.path.isfile(Destination+ curent_path+file2):
            replace(CurrentDir+curent_path+file2,Destination+ curent_path+file2)
        else:
            replace(CurrentDir+curent_path+file2,Destination+ curent_path+file2)

replace(CurrentDir+"/misc/templates/bash_profile.tpl",Bash_File+'/app-root/data/.bash_profile')



f = open(repoDir + '/misc/templates/httpd.conf.tpl', 'r')
conf = f.read().replace('{{OPENSHIFT_INTERNAL_IP}}', internalIp).replace('{{OPENSHIFT_REPO_DIR}}', repoDir).replace('{{OPENSHIFT_RUNTIME_DIR}}', runtimeDir)
f.close()

f = open(runtimeDir + '/srv/httpd/conf/httpd.conf', 'w')
f.write(conf)
f.close()

f = open(repoDir + '/misc/templates/php.ini.tpl', 'r')
conf = f.read().replace('{{OPENSHIFT_INTERNAL_IP}}', internalIp).replace('{{OPENSHIFT_REPO_DIR}}', repoDir).replace('{{OPENSHIFT_RUNTIME_DIR}}', runtimeDir)
f.close()

f = open(runtimeDir + '/srv/php/etc/apache2/php.ini', 'w')
f.write(conf)
f.close()
