# สัญญาอัจฉริยะเกม Rock, Paper, Scissors (RPS)

สัญญาอัจฉริยะนี้ได้ถูกออกแบบมาเพื่อให้เล่นเกม Rock, Paper, Scissors ได้อย่างปลอดภัยและเป็นธรรมโดยใช้เทคโนโลยีบล็อกเชน Ethereum สัญญานี้ใช้โครงสร้าง commit-reveal เพื่อรับประกันความเป็นธรรมและป้องกันปัญหา front-running นอกจากนี้ยังมีกลไกการจัดการเวลาเพื่อควบคุมความก้าวหน้าของเกมและป้องกันไม่ให้เงินถูกล็อคไว้ในสัญญาอย่างไม่มีกำหนด

## คุณสมบัติหลัก

### 1. การป้องกันการล็อคเงินไว้ในสัญญา

สัญญานี้มีกลไกหลายอย่างเพื่อป้องกันการล็อคเงิน:

- **การถอนเงินที่จำกัดเวลา**: หากผู้เล่นเพียงคนเดียวเข้าร่วมเกมและไม่มีผู้เล่นคนที่สองเข้าร่วมภายในช่วงเวลาที่กำหนด (10 นาที) ผู้เล่นนั้นสามารถถอนเงินที่เขาได้วางเดิมไว้โดยไม่มีโทษ
- **การรีเซ็ตเกมอัตโนมัติ**: หลังจากเกมจบ ไม่ว่าจะผ่านการเล่นปกติหรือเนื่องจากหมดเวลา สถานะของสัญญาจะถูกรีเซ็ตเพื่อให้ผู้เล่นใหม่สามารถเข้าร่วมได้และรับประกันว่าเงินจะไม่ติดอยู่ในสัญญา

### 2. โครงสร้างการ Commit และ Reveal

เพื่อป้องกัน front-running และให้แน่ใจว่าผู้เล่นทำการเลือกของตนโดยไม่รู้ทางเลือกของฝ่ายตรงข้ามล่วงหน้า สัญญานี้ใช้โครงสร้าง commit-reveal:

- **Commit**: ผู้เล่น commit ต่อการเลือกของตนโดยส่งแฮชของการเลือกควบคู่ไปกับ nonce ลับ การ commit นี้จะถูกเก็บไว้ในบล็อกเชนแต่ไม่เปิดเผยการเลือกจริง
- **Reveal**: หลังจากผู้เล่นทั้งสองได้ทำการ commit แล้ว พวกเขาจะเปิดเผยการเลือกของตนโดยส่งการเลือกต้นฉบับและ nonce สัญญาจะตรวจสอบว่าการเปิดเผยตรงกับแฮชที่ commit ไว้ก่อนหน้านี้

### 3. การจัดการกับความล่าช้าและเกมที่ไม่สมบูรณ์

สัญญาจัดการกับสถานการณ์ที่ผู้เล่นอาจไม่เข้าร่วมหรือสิ้นสุดเกมไม่ได้:

- **การจำกัดเวลาให้ผู้เล่นที่สองเข้าร่วม**: หากมีผู้เล่นเพียงคนเดียวที่เข้าร่วมเกมภายใน 10 นาที ผู้เล่นนั้นสามารถถอนเงินของตนได้ ซึ่งจะทำให้เกมรีเซ็ต
- **การตรวจสอบการสิ้นสุด**: สัญญาตรวจสอบอย่างต่อเนื่องว่าทั้งสองผู้เล่นได้เปิดเผยการเลือกของตนหรือไม่ หากมีเพียงผู้เล่นคนเดียวที่เปิดเผยการเลือกภายในกรอบเวลาที่เหมาะสม สัญญาจะอนุญาตให้รีเซ็ตหรือถอนเงินที่วางเดิมได้

### 4. การตัดสินและการแจกจ่ายรางวัล

เมื่อทั้งสองผู้เล่นได้เปิดเผยการเลือกของตน สัญญาจะดำเนินการตามลอจิกต่อไปนี้เพื่อตัดสินผู้ชนะและแจกจ่ายรางวัล:

- **ลอจิกเกม**: สัญญาเปรียบเทียบการเลือกของทั้งสองผู้เล่นตามกฎเกมปกติ (หินชนะกรรไกร, กรรไกรชนะกระดาษ, กระดาษชนะหิน)
- **การแจกจ่ายรางวัล**: หากมีผู้ชนะชัดเจน รางวัลทั้งหมดจะถูกโอนไปยังผู้ชนะ ในกรณีเสมอ สัญญาจะแบ่งรางวัลอย่างเท่าเทียมระหว่างทั้งสองผู้เล่น

## การใช้งานสัญญา

เพื่อเข้าร่วมเกม:
1. ผู้เล่นต้องอยู่ในรายการที่อยู่ที่ได้รับอนุญาต
2. ผู้เล่นส่ง 1 ETH พร้อมกับคำมั่นสัญญาไปยังฟังก์ชัน `addPlayer`
3. หลังจากที่ผู้เล่นทั้งสองเข้าร่วมแล้ว พวกเขาใช้ `commitChoice` เพื่อ commit การเลือกของตนและ `revealChoice` เพื่อเปิดเผยและสรุปเกม

สัญญานี้ให้ความแน่ใจว่ามีสภาพแวดล้อมที่ยุติธรรมและปลอดภัยสำหรับการเล่นเกม Rock, Paper, Scissors ด้วยคุณสมบัติโปร่งใสและความปลอดภัยของบล็อกเชน Ethereum.