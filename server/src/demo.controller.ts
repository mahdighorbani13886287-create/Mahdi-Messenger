import { Body, Controller, Get, Post } from '@nestjs/common';

type DemoMessage = { id: number; text: string; createdAt: string };
const messages: DemoMessage[] = [
  { id: 1, text: 'Demo API is running. This is not an encrypted message.', createdAt: new Date().toISOString() },
];

@Controller()
export class DemoController {
  @Get('/health')
  health() {
    return { status: 'ok', service: 'mahdi-messenger-api', productionReady: false };
  }

  @Get('/demo/messages')
  getMessages() {
    return messages;
  }

  @Post('/demo/messages')
  addMessage(@Body() body: { text?: string }) {
    const text = (body?.text || '').trim();
    if (!text || text.length > 2000) {
      return { error: 'Message must contain 1 to 2000 characters.' };
    }
    const message = { id: Date.now(), text, createdAt: new Date().toISOString() };
    messages.push(message);
    return message;
  }
}
