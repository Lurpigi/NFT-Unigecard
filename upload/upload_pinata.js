import axios from "axios";
import FormData from "form-data";
import dotenv from "dotenv";
import fs from "fs";
import rfs from "recursive-fs";
import basePathConverter from "base-path-converter";

dotenv.config();

const JWT = process.env.PINATA_JWT;
const imagesPath = process.env.DATA + "/cards";
const metadataPath = process.env.DATA + "/metadata";

async function pinFileToIPFS(folderPath) {
  try {
    const { files } = await rfs.read(folderPath);

    let data = new FormData();

    for (const file of files) {
      data.append(`file`, fs.createReadStream(file), {
        filepath: basePathConverter(folderPath, file),
      });
    }

    const res = await axios.post(process.env.PINATA_URL, data, {
      headers: {
        Authorization: `Bearer ${JWT}`,
        ...data.getHeaders(),
      },
      onUploadProgress: (progressEvent) => {
        const percentCompleted = Math.round(
          (progressEvent.loaded * 100) / progressEvent.total
        );
        console.log(`Upload progress: ${percentCompleted}%`);
      },
    });

    console.log(res.data.IpfsHash); // CID cartella
    return res.data.IpfsHash;
  } catch (error) {
    console.error("Errore:", error);
  }
}

function prepareMetadata(imagesCID) {
  try {
    const files = fs.readdirSync(metadataPath);

    files.forEach((file) => {
      if (file.endsWith(".json")) {
        const filePath = `${metadataPath}/${file}`;
        let jsonData = JSON.parse(fs.readFileSync(filePath, "utf-8"));
        const id = jsonData.id;
        jsonData.image = `ipfs://${imagesCID}/${id}.png`;
        fs.writeFileSync(filePath, JSON.stringify(jsonData, null, 2), "utf-8");
        console.log(`updated: ${file}`);
      }
    });

    console.log("updated all metadata");
  } catch (error) {
    console.error("error:", error);
  }
}

console.log("Starting to upload images folder...");
pinFileToIPFS(imagesPath).then((imagesCID) => {
  console.log("Images folder uploaded. CID:", imagesCID);
  fs.writeFileSync("imagesCID.txt", imagesCID, "utf-8");
  console.log("Saved imagesCID to imagesCID.txt");

  console.log("Preparing metadata...");
  prepareMetadata(imagesCID);

  console.log("Starting to upload metadata folder...");
  pinFileToIPFS(metadataPath).then((metadataCID) => {
    console.log("Metadata folder uploaded. CID:", metadataCID);
    fs.writeFileSync("metadataCID.txt", metadataCID, "utf-8");
    console.log("Saved metadataCID to metadataCID.txt");

    console.log("Process completed successfully.");
  });
});
