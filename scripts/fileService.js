
/*************************************************
  Copyright (C),2018-2022
  Filename:  fileService.js
  Author: radarzhhua     Version:   1.0     Date: 2018.10.20
  Description:   此JS是应用于Koa2框架上的常用文件操作封装,也可以直接用于node.js
                所有方法均返回了promise，可适用于async/await
                目前只封装了读txt文件，读json文件，写txt文件，写json文件，
                其中写txt文件区分追加模式还是改写模式
                需要增加readline功能
                需要node.js 7.6以上
  email:radarzhhua@gmail.com
*************************************************/

const fs = require('fs');

//读TXT文件
/**
 * @param
 * fileName  文件名,记住这个文件名是相对于工程目录的。如果直接用于node.js,则是相对于脚本文件的
 * @return 如果找不到，返回一个null，如果能找到，返回读取的全部字符串
 */
function readTxt(fileName){
  return new Promise((resolve, reject) => {
      fs.readFile(fileName, function (err, data) {
         if (err){
           console.log(err);
           resolve(null);
         }else{
           resolve(data.toString());
         }
      });
  });
}

//读json文件
/**
 * @param
 * fileName  文件名,记住这个文件名是相对于工程目录的。如果直接用于node.js,则是相对于脚本文件的
 * @return 如果找不到，返回一个{}，如果能找到，返回转换后的json对象
 */
function readJson(fileName){
  return new Promise((resolve, reject) => {
      fs.readFile(fileName, function (err, data) {
         if (err){
           resolve({});
         }else{
           resolve(JSON.parse(data));
         }
      });
  });
}

//写入txt文件，如果不存在就创建
/**
 * @param
 * fileName  文件名,记住这个文件名是相对于工程目录的。如果直接用于node.js,则是相对于脚本文件的
 * content  写入内容
 * isAppend 是否追加
 * @return 写入成功返回 'succ',有错误返回 'err'
 */
function writeTxt(fileName,content,isAppend){
  let flag = isAppend ? 'a' : 'w';
  return new Promise((resolve, reject) => {
    fs.writeFile(fileName,content,{flag:flag},function(err){
      if (err){
        console.log(err);
        resolve('err');
      }else{
        resolve('succ');
      }
    });
  });
}

//写入json文件，如果不存在就创建
/**
 * @param
 * fileName  文件名,记住这个文件名是相对于工程目录的。如果直接用于node.js,则是相对于脚本文件的
 * content  写入内容
 * @return 写入成功返回 'succ',有错误返回 'err'
 */
function writeJson(fileName,content){
  content = JSON.stringify(content);
  return new Promise((resolve, reject) => {
    fs.writeFile(fileName,content,function(err){
      if (err){
        console.log(err);
        resolve('err');
      }else{
        resolve('succ');
      }
    });
  });
}


module.exports = {
  readTxt:readTxt,
  readJson:readJson,
  writeTxt:writeTxt,
  writeJson:writeJson
}
