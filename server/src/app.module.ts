import { Module } from '@nestjs/common';
import { DemoController } from './demo.controller';
import { AdminController } from './admin.controller';
@Module({controllers:[DemoController,AdminController]}) export class AppModule {}
