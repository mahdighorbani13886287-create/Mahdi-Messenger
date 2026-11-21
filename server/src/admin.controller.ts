import { Body, Controller, Delete, Get, Param, Post, Put } from '@nestjs/common';
type WordRule={id:string;word:string;action:'block'|'replace'|'warn'};
type AdminAccount={id:string;username:string;role:'owner'|'admin'|'moderator'|'support'};
let settings={fileLimitMode:'custom',maxFileSizeGb:5,userQuotaGb:20};
const bannedWords:WordRule[]=[];
const admins:AdminAccount[]=[{id:'admin-owner',username:'owner',role:'owner'}];
@Controller()
export class AdminController {
 @Get('/admin/settings') getSettings(){return settings;}
 @Put('/admin/settings') updateSettings(@Body() body:Partial<typeof settings>){
  const mode=body.fileLimitMode??settings.fileLimitMode, max=Number(body.maxFileSizeGb), quota=Number(body.userQuotaGb);
  if(!['custom','unlimited'].includes(mode)) return {error:'Invalid fileLimitMode'};
  if(!Number.isFinite(max)||max<0.01||max>10000||!Number.isFinite(quota)||quota<0.01||quota>1000000)return {error:'Invalid file size or quota'};
  settings={fileLimitMode:mode,maxFileSizeGb:max,userQuotaGb:quota};return settings;
 }
 @Get('/admin/banned-words') getWords(){return bannedWords;}
 @Post('/admin/banned-words') addWord(@Body() body:{word?:string;action?:string}){
  const word=(body?.word??'').trim(),action=body?.action??'block';
  if(!word||word.length>100)return {error:'Word must contain 1 to 100 characters'};
  if(!['block','replace','warn'].includes(action))return {error:'Invalid action'};
  if(bannedWords.some(x=>x.word.toLocaleLowerCase()===word.toLocaleLowerCase()))return {error:'Word already exists'};
  const item:WordRule={id:`word-${Date.now()}`,word,action:action as WordRule['action']};bannedWords.push(item);return item;
 }
 @Delete('/admin/banned-words/:id') deleteWord(@Param('id') id:string){const i=bannedWords.findIndex(x=>x.id===id);if(i<0)return {deleted:false};bannedWords.splice(i,1);return {deleted:true};}
 @Get('/admin/admins') getAdmins(){return admins;}
 @Post('/admin/admins') addAdmin(@Body() body:{username?:string;role?:string}){
  const username=(body?.username??'').trim(),role=body?.role??'moderator';
  if(!username||username.length>50)return {error:'Invalid username'};
  if(!['admin','moderator','support'].includes(role))return {error:'Invalid role'};
  if(admins.some(x=>x.username.toLowerCase()===username.toLowerCase()))return {error:'Admin already exists'};
  const item:AdminAccount={id:`admin-${Date.now()}`,username,role:role as AdminAccount['role']};admins.push(item);return item;
 }
}
